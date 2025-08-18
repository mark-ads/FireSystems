from pydantic import BaseModel, IPvAnyAddress, Field, root_validator, ConfigDict
from typing import Dict, Literal, Union, Optional
from collections import OrderedDict
from dataclasses import dataclass, field


class ArduinoConfig(BaseModel):
    ip: IPvAnyAddress = '192.168.1.13'
    water_pressure_limit: float = 2.0
    air_pressure_limit: float = 2.0
    air_temp_limit: float = 50.0
    water_temp_limit: float = 50.0
    out_temp_limit: float = 70.0
    wp_temp_limit: float = 70.0
    change_motor_direction: bool = False


class CameraConfig(BaseModel):
    ip: IPvAnyAddress = '192.168.1.20'
    onvif_port: int = 8899
    login: str = 'admin'
    password: str = ''
    fps: int = 25
    auto_gain: int = 1
    auto_exposure: bool = True
    gain: int = 1
    exposure: int = 1
    brightness: float = 35.0
    contrast: float = 32.0
    colorsaturation: float = 34.0
    flip: bool = False
    mirror: bool = False

class ZondConfig(BaseModel):
    arduino: ArduinoConfig = Field(default_factory=ArduinoConfig)
    camera: CameraConfig = Field(default_factory=CameraConfig)


class ZondPair(BaseModel):
    name: str = 'System'
    front: ZondConfig = Field(default_factory=ZondConfig)
    back: ZondConfig = Field(default_factory=ZondConfig)


class ProgramConfig(BaseModel):
    ip: IPvAnyAddress = '192.168.1.10'


def default_zond_pairs():
    return OrderedDict({
        "system_1": ZondPair(
            name="Котёл",
            front=ZondConfig(),
            back=ZondConfig()
        )
    })


class Settings(BaseModel):
    program_settings: ProgramConfig = Field(default_factory=ProgramConfig)
    zond_pairs: Dict[str, ZondPair] = Field(default_factory=default_zond_pairs)

    model_config = ConfigDict(
        extra='forbid',
        validate_assignment=True,
        populate_by_name=True
    )


@dataclass
class Command:
    target: Literal['front', 'back']
    command: str
    value: Optional[Union[int, float, bool]] = field(default=None)